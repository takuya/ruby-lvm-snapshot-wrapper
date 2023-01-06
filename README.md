# Takuya::Lvm::Snapshot

Wrapper for lvm, to use lvm snapshot. 
## example 

This package make easy to Take Snapshot and Backup.

```ruby
require "takuya/lvm_snapshot"
LvmSnapShot = Takuya::LvmSnapShot

LvmSnapShot.new('vg0').enter_snapshot{
    ## backup from snapshot 
    FileUtils.cp_r('/mnt/var/lib/mysql', '/nfs/backup/mysql')
}
```

Using proc call, We can focus on backup steps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'takuya-lvm-snapshot'
```
And then execute:

```sh
bundle config set --local path '.bundle'
bundle install
```
Or install it yourself as:
```sh
gem install takuya-lvm-snapshot
```

### Installation from github
Add Following line into Gemfile.
```
gem 'takuya-lvm-snapshot', git: 'https://github.com/takuya/ruby-lvm-snapshot-wrapper.git'
```

## Usage

create / list / delete lvm snapshot
```ruby
require "takuya/lvm_snapshot"
LvmSnapShot = Takuya::LvmSnapShot

lvsnap = LvmSnapShot.new('vg_name')
lvsnap.create('snap_01')
lvsnap.exists('snap_01')
lvsnap.mount('snap_01','/mnt')
lvsnap.unmount('snap_01','/mnt')
lvsnap.remove('snap_01')
```

This package make easy to Take Snapshot and backup.

```ruby
require "takuya/lvm_snapshot"
LvmSnapShot = Takuya::LvmSnapShot

LvmSnapShot.new('vg0').enter_snapshot{|mnt|
    ## make working snapshot.
    ## backup from snapshot.
    ## no stopping sevices.
    FileUtils.cp_r('/mnt/var/lib/mysql', '/nfs/backup/mysql')
}
```


#### Example.
Make use of LVM Snap Shot allows us  to Backup without stopping services.


```ruby
require "takuya/lvm_snapshot"
LvmSnapShot = Takuya::LvmSnapShot

LvmSnapShot.new('vg0','lv0','20G','/mnt').enter_snapshot{|mnt|
    ## backup from snapshot 
    src="#{mnt}/var/lib/libvirt/images/my-vm.qcow2"
    cmd="rsync -a '#{src}' myserver:~/my-backup "
    `#{cmd}`
}
```

## Testing 
```sh
bundle exec rspec spec 
```
## Releasing
```sh
bundle exec rake release
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake ` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/takuya/ruby-lvm-snapshot-wrapper/.
