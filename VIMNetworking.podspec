Pod::Spec.new do |s|
  s.name             = "VIMNetworking"
  s.version          = "1.0.0"
  s.summary          = "The Vimeo iOS SDK"
  s.description      = <<-DESC
                        VIMNetworking is an Objective-C library that enables interaction with the Vimeo API. It handles authentication, request submission and cancellation, and video upload. Advanced features include caching and powerful model object parsing.
                       DESC
  s.homepage         = "https://github.com/vimeo/VIMNetworking"
  s.license          = 'MIT'
  s.author           = { "Alfie Hanssen" => "" }
  s.source           = { 
    :git => "https://github.com/FastSociety/VIMNetworking.git", 
    :tag => s.version.to_s
  }
  s.social_media_url = 'https://twitter.com/vimeo'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'VIMNetworking/**/*.h'
  s.source_files = 'VIMNetworking/**/*{h,m}'

  s.frameworks = 'Social', 'Accounts', 'MobileCoreServices', 'AVFoundation', 'SystemConfiguration'
  # http://stackoverflow.com/a/17735833/51700 version is captured in Podfile
  s.dependency 'VIMObjectMapper'
  s.dependency 'AFNetworking'

end
