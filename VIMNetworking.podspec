#
# Be sure to run `pod lib lint VIMNetworking.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
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
  s.source           = { :git => "https://github.com/vimeo/VIMNetworking.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vimeo'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'VIMNetworking/**/*{h,m}'
  s.resource_bundles = {
    'VIMNetworking' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # could replace External/AFNetworking with pod dep
  # s.dependency 'AFNetworking', '~> 2.3'
end
