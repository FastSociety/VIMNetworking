#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "VIMNetworking"
  s.version          = "1.0.0"
  s.summary          = "The Vimeo iOS SDK"
  s.description      = <<-DESC
                        VIMNetworking is an Objective-C library that enables interaction with the Vimeo API. It handles authentication, request submission and cancellation, and video upload. Advanced features include caching and powerful model object parsing.
                       DESC
  s.homepage         = "https://github.com/vimeo/VIMNetworking"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Alfie Hanssen" => "" }
  s.source           = { 
    :git => "https://github.com/vimeo/VIMNetworking.git", 
    :tag => s.version.to_s,
    :submodules => true
  }
  s.social_media_url = 'https://twitter.com/vimeo'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.public_header_files = 'VIMNetworking/**/*.h'
  s.prefix_header_file = 'VIMNetworking/VIMNetworking-Prefix.pch'
  s.source_files = 'VIMNetworking/**/*{h,m}'
  #  s.resource_bundles = {
  #    'VIMNetworking' => ['Pod/Assets/*.png']
  #  }

  s.frameworks = 'Social', 'Accounts', 'MobileCoreServices', 'AVFoundation', 'SystemConfiguration'
  # http://stackoverflow.com/a/17735833/51700 version is captured in Podfile
  s.dependency 'AFNetworking'
end
