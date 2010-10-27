Project.configure do |project|
  project.email_notifier.emails = ['alex@stinky.com', 'erector@googlegroups.com']
  project.email_notifier.from = 'alexch+erectorci@gmail.com'
  project.build_command = "./cruise_build.sh"
end
