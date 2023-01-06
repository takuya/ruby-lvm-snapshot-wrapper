# frozen_string_literal: true

RSpec.describe Takuya::LvmSnapShot do

  LvmSnapShot = Takuya::LvmSnapShot

  it "has a version number" do
    expect(LvmSnapShot::VERSION).not_to be nil
  end

  it "can list snapshots" do 
    lvs = LvmSnapShot.new('vg')
    stdout = "  LV\n  snap_2023_01_05\n  snap_2023_01_06\n"
    stderr = ''
    process =instance_double(Process::Status, exitstatus:0 )
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ret = lvs.list()
    expect(ret.size).to eq(2)
  end

  it "can check exists" do 
    lvs = LvmSnapShot.new('vg')

    ## mock
    stdout = "  LV\n  snap_2023_01_05\n  snap_2023_01_06\n"
    stderr = ''
    process =instance_double(Process::Status, exitstatus:0 )
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ## 
    ret = lvs.exists('snap_2023_01_05')
    expect(ret).to eq(true)
    ret = lvs.exists('snap_2023_01_07')
    expect(ret).to eq(false)
  end

  it "can create snapshot" do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    stdout = "  Logical volume \"#{snapname}\" created."
    stderr = ''
      process =instance_double(Process::Status, exitstatus:0 )
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ret = lvs.create(snapname)
    expect(ret).to eq(snapname)
  end

  it "can create auto named snapshot" do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    expected_name = "snap_#{Date.today.strftime('%Y_%m_%d')}"
    # mock
    stdout = "  Logical volume \"#{expected_name}\" created."
    stderr = ''
      process =instance_double(Process::Status, exitstatus:0 )
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ret = lvs.create()
    expect(ret).to eq(expected_name)
  end

  it " fails to create snapshot with already named" do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    stdout = %s|Logical Volume "#{snapname}" already exists in volume group "vg"|
    stderr = ''
    process =instance_double(Process::Status, exitstatus:5 )
    ## exec
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ret = lvs.create(snapname)
    expect(ret).to eq(false)
  end

  it "can remove snapshot" do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    stdout = %s|Logical volume "#{snapname}" successfully removed|
    stderr = ''
    process =instance_double(Process::Status, exitstatus:0 )
    ## exec
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ret = lvs.remove(snapname)
    expect(ret).to eq(true)
  end

  it "fails to remove noexist snapshot" do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    stdout = %s|Failed to find logical volume "vg/#{snapname}"|
    stderr = ''
    process =instance_double(Process::Status, exitstatus:5 )
    allow(lvs).to receive(:exec_cmd).and_return([process , stdout, stderr]) 
    ## exec
    ret = lvs.remove(snapname)
    expect(ret).to eq(false)
  end
  
  it "can mount snapshot " do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    process =instance_double(Process::Status, exitstatus:0 )
    allow(lvs).to receive(:exec_cmd).and_return([process , '', '']) 
    allow(lvs).to receive(:exists).and_return(true) 
    allow(lvs).to receive(:mounted).and_return(false) 
    ## exec
    ret = lvs.mount(snapname)
    expect(ret).to eq(true)
  end
  it "fails to mount snapshot, no exists snapshot " do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    allow(lvs).to receive(:exists).and_return(false) 
    ## exec
    ret = lvs.mount(snapname)
    expect(ret).to eq(false)
  end
  it "fails to mount snapshot, no exists mount point " do
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    stdout = %s|mount: /mnt: special device /dev/mapper/vg-#{snapname} does not exist.|
    process =instance_double(Process::Status, exitstatus:32 )
    allow(lvs).to receive(:exec_cmd).and_return([process , '', '']) 
    allow(lvs).to receive(:exists).and_return(true) 
    allow(lvs).to receive(:mounted).and_return(false) 
    ## exec
    ret = lvs.mount(snapname)
    expect(ret).to eq(false)
  end

  it "can check already used mountpoint" do 
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    allow(File).to receive(:open).and_return(StringIO.new("/dev/sda4 /mnt ext4 rw,relatime 0 0"))
    ## exec
    ret = lvs.mounted(snapname)
    expect(ret).to eq(true)
  end

  it "can check already mounted snapshot " do 
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    allow(File).to receive(:open).and_return(StringIO.new("/dev/vg-#{snapname} /mnt ext4 rw,relatime 0 0"))
    ## exec
    ret = lvs.mounted(snapname)
    expect(ret).to eq(true)
  end

  it "can check mountable " do 
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    allow(File).to receive(:open).and_return(StringIO.new("/dev/vg-dummy /mnt2 ext4 rw,relatime 0 0"))
    ## exec
    ret = lvs.mounted(snapname)
    expect(ret).to eq(false)
  end

  it "can use proc with snapshot " do 
    lvs = LvmSnapShot.new('vg')
    ## test name 
    snapname = "snap_1234"
    # mock
    allow(lvs).to receive(:create).and_return(snapname) 
    allow(lvs).to receive(:mount).and_return(true) 
    allow(lvs).to receive(:unmount).and_return(true) 
    allow(lvs).to receive(:remove).and_return(true) 
    ## exec
    lvs.enter_snapshot(snapname){|mnt|
      expect(mnt).to eq('/mnt')
    }
  end

end

