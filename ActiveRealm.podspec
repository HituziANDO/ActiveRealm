Pod::Spec.new do |s|
  s.name         = "ActiveRealm"
  s.version      = "0.1.2"
  s.summary      = "ActiveRealm is Active Record library using Realm."
  s.description  = <<-DESC
  ActiveRealm is Active Record library using Realm for Objective-C/Swift, inspired by ActiveRecord of Ruby on Rails.
                   DESC
  s.author       = "Hituzi Ando"
  s.homepage     = "https://github.com/HituziANDO/ActiveRealm"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.platform     = :ios, "9.3"
  s.source       = { :git => "https://github.com/HituziANDO/ActiveRealm.git", :tag => "#{s.version}" }
  s.source_files  = "ActiveRealm/ActiveRealm/**/*.{h,m}"
  s.exclude_files = "ActiveRealm/build/*", "ActiveRealm/Framework/*", "ActiveRealmSample/*", "ActiveRealmSwiftSample/*", "README.md"
  s.requires_arc = true
  s.dependency 'Realm'
end
