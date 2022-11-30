#
#  Be sure to run `pod spec lint RadioView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "RadioView"
  spec.version      = "0.0.2"
  spec.summary      = "OTUS Homework module for demonstrations"


  spec.description  = <<-DESC
		 This is demo lesson project for OTUS Homework
                   DESC

  spec.homepage     = "https://github.com/rubis-vladimir/OTUS-RadioView"
  spec.license      = { :type => "MIT" }

  spec.author             = { "rubis-vladimir" => "84345727+rubis-vladimir@users.noreply.github.com" }

  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/rubis-vladimir/OTUS-RadioView.git", :tag => "#{spec.version}" }

  spec.source_files  = "RadioView/**/*.{swift,xcassets,json,h,m}"

  spec.public_header_files = "RadioView/**/*.h"
  spec.swift_version = "5.0"

end
