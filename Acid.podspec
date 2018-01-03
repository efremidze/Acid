Pod::Spec.new do |s|
  s.name             = 'Acid'
  s.version          = '0.0.1'
  s.summary          = 'Liquid Effects Library'
  s.homepage         = 'https://github.com/efremidze/Acid'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'efremidze' => 'efremidzel@hotmail.com' }
  s.source           = { :git => 'https://github.com/efremidze/Acid.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*.swift'
end
