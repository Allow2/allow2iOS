Pod::Spec.new do |s|
    s.name        = "Allow2"
    s.version     = "0.8.4"
    s.summary     = "Allow2 Parental Freedom Platform makes it easy to add parental controls to your apps"
    s.description = "Easily add quota, time management, time limits, bans, chores and much more to your app. By giving the Parent control mechanisms to moderate usage, you give them reasons to want to download, buy, and subscribe to your service. Without controls, parents are more likely to just not download the apps."
    s.homepage    = "https://github.com/Allow2/Allow2iOS"
    s.license     = { :type => 'Open Source', :file => 'LICENSE' }
    s.authors     = { "Allow2" => "ceo@allow2.com" }

    s.requires_arc = true
    s.ios.deployment_target = "10.0"
    s.source   = { :git => "https://github.com/Allow2/Allow2iOS.git", :tag => s.version }
    s.pod_target_xcconfig =  {
        'SWIFT_VERSION' => '4.0',
    }
    s.source_files = "Allow2Framework/**/*.swift", "Allow2Framework/**/*.storyboard", "Allow2Framework/**/*.xcassets"
end