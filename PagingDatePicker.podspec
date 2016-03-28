#
# Be sure to run `pod lib lint PagingDatePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PagingDatePicker"
  s.version          = "0.1.0"
  s.summary          = "A calendar view date picker with paging."
  s.description      = <<-DESC
  This library consists of two components that can be used on it's own or together. 
  One is a swipeable month picker and the other is a paging calendar date picker showing one month on each page.
  The month picker can be used as navigation header for the calendar date picker.
                       DESC

  s.homepage         = "https://github.com/lammertw/PagingDatePicker"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Lammert Westerhoff" => "westerhoff@gmail.com" }
  s.source           = { :git => "https://github.com/lammertw/PagingDatePicker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/lwesterhoff'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PagingDatePicker' => ['Pod/Assets/*.png']
  }

  s.dependency 'DynamicColor', '~> 2.4'
  s.dependency 'RSDayFlow', '~> 1.4'
  s.dependency 'SwiftDate', '~> 3.0'
end
