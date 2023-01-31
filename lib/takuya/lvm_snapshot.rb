# frozen_string_literal: true

require_relative "lvm_snapshot/version"
require 'open3'
require 'date'


class Takuya::LvmSnapShot
  class Error < StandardError; end
end
   
class Takuya::LvmSnapShot
  attr_accessor :vg_name, :lv_size, :mnt_point,:lv_name
  def initialize(vg_name,lv_name='lv',lv_size='20G',mnt_point='/mnt')
    @vg_name=vg_name
    @lv_size=lv_size
    @mnt_point = mnt_point
    @lv_name = lv_name
  end
  def list()
    cmd = 'lvs -o lv_name -S "lv_attr=~[^s.*]" #{@vg_name}'
    process , stdout, stderr = self::exec_cmd(cmd)
    return false unless process.exitstatus == 0 
    stdout.lines.map(&:strip).reject{|e|e=~/^LV/}
  end
  def exists(name)
    self.list.one?(/^#{name}$/)
  end
  def create(name=nil,lv_name=@lv_name, vg_name=@vg_name)
    name =  "snap_#{Date.today.strftime('%Y_%m_%d')}"  if name.nil? || name.empty?
    cmd = "lvcreate -s -L #{@lv_size} -n '#{name}' '#{vg_name}/#{lv_name}'"
    process , stdout, stderr = self.exec_cmd(cmd)
    if process.exitstatus == 0  then 
      return name 
    else 
      return false
    end
  end

  def remove(name)
    target = name
    target = "#{@vg_name}/#{name}" if @vg_name

    cmd = "lvremove -y -S 'lv_attr=~[^s.*]' '#{target}'"
    # p cmd
    process , stdout, stderr = self.exec_cmd(cmd)
    return process.exitstatus == 0
  end
  
  def mount(snap_name,mount_point=@mnt_point)
    return false unless self.exists(snap_name)
    return false if self.mounted(snap_name,mount_point)

    target = "/dev/mapper/#{@vg_name}-#{self.escape_lv_name(snap_name)}" 
    cmd = "mount -o ro,nouuid '#{target}' '#{mount_point}' "
    process , stdout, stderr = self.exec_cmd(cmd)
    return process.exitstatus == 0
  end

  def unmount(snap_name,mount_point=@mnt_point)
    return false unless self.exists(snap_name)
    return false unless self.mounted(snap_name,mount_point)

    target = "/dev/mapper/#{@vg_name}-#{snap_name}" 
    cmd = "umount '#{mount_point}'"
    # p cmd
    process , stdout, stderr = self.exec_cmd(cmd)
    # p [ process , stdout, stderr ]
    return process.exitstatus == 0
  end
  def escape_lv_name(name)
    return name.gsub('-','--')
  end

  def mounted(snap_name,mount_point='/mnt')

    mounts =  File.open('/proc/mounts').read.lines

    ## mount_pointが占拠されてるか
    return true if mounts.one?(/ #{mount_point} /) 
    ## すでにマウントしてないか
    dev = "/dev/mapper/#{@vg_name}-#{self.escape_lv_name(snap_name)}"
    return mounts.one?(/^#{dev} /)
  end

  def enter_snapshot(lv_name=@lv_name,&proc)
    name,err,pwd = nil,nil,Dir.pwd
    begin 
      name = self.create(name,lv_name)
      raise 'snapshot creation failed' unless name
      ret = self.mount(name)
      raise 'snapshot mounting failed' unless ret
      proc.call(@mnt_point)
    rescue => e 
      err = e 
    ensure
      Dir.chdir(pwd)
      self.unmount(name)
      self.remove(name)
    end
    raise err unless err.nil?
    return true
  end
  def exec_cmd(cmd)
    cmd = "sudo #{cmd}"
    stdout, stderr,process = Open3.capture3(cmd)
    return [process , stdout, stderr]
  end
end


