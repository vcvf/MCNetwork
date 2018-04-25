
Pod::Spec.new do |s|
  s.name             = 'MCNetwork'
  s.version          = '0.1.0'
  s.summary          = 'MCNetwork.'
  s.description      = '基础网络组件库'

  s.homepage         = 'https://github.com/vcvf/MCNetwork'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1594717129@qq.com' => '1594717129@qq.com' }
  s.source           = { :git => 'https://github.com/vcvf/MCNetwork.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.public_header_files = 'MCNetwork/MCNetwork.h'
  s.source_files = 'MCNetwork/Classes'
  
  # s.resource_bundles = {
  #   'MCNetwork' => ['MCNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'CFNetwork'
  s.dependency 'AFNetworking', '~> 3.1.0'
  
  s.subspec 'Request' do |ss|
      ss.source_files = 'MCNetwork/Classes/Request/**/*'
  end
  
  s.subspec 'Serialization' do |ss|
      ss.source_files = 'MCNetwork/Classes/Serialization/**/*'
  end
  
end
