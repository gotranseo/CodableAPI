Pod::Spec.new do |s|
  s.name             = 'CodableAPI'
  s.version          = '0.3.0'
  s.summary          = 'A set of Swift helpers for interacting with APIs in a Codable format.'
  s.description      = <<-DESC
  Use Codable models to craft requests and receive responses from APIs. 
                       DESC

  s.homepage         = 'https://github.com/gotranseo/CodableAPI'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'transeo' => 'jimmy@gotranseo.com' }
  s.source           = { :git => 'https://github.com/gotranseo/CodableAPI.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'CodableAPI/Classes/**/*'
end
