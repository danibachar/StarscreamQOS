Pod::Spec.new do |s|
  s.name         = "StarscreamQOS"
  s.version      = "0.0.1"
  s.summary      = "A QOS wrapper around Starscream in Swift."
  s.homepage     = "https://github.com/danibachar/StarscreamQOS"
  s.license           = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Name' => 'danibachar89@gmail.com' }
  s.source       = { :git => 'https://github.com/danibachar/StarscreamQOS.git',  :tag => "#{s.version}"}
  s.ios.deployment_target = '12.0'
  # s.osx.deployment_target = '10.10'
  # s.tvos.deployment_target = '9.0'
  # s.watchos.deployment_target = '2.0'
  s.source_files = 'Sources/**/*.swift'
  s.swift_version = '5.0'

  s.dependency 'Starscream'
end
