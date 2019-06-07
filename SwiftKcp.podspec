Pod::Spec.new do |s|
  s.name             = 'SwiftKcp'
  s.version          = '0.1.3'
  s.summary          = 'KCP - A Fast and Reliable ARQ Protocol'

  s.description      = <<-DESC
KCP - A Fast and Reliable ARQ Protocol
                       DESC

  s.homepage         = 'https://github.com/dinobei/SwiftKcp'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dinobei' => 'dinobei89@gmail.com' }
  s.source           = { :git => 'https://github.com/dinobei/SwiftKcp.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.swift_version    = '4'

  s.source_files     = 'SwiftKcp/*.{swift,c,h}'
  s.preserve_paths   = 'SwiftKcp/module.map'
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
end
