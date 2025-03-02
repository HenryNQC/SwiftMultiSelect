Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "SwiftMultiSelect"
s.summary = "SwiftMultiSelect lets a user select multiple contacts from PhoneBook or from custom list"
s.requires_arc = true

# 2
s.version = "0.2.6"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Luca Becchetti" => "luca.becchetti@brokenice.it" }


# 5 - Replace this URL with your own Github page's URL (from the address bar)
s.homepage = "https://github.com/lucabecchetti/swiftmultiselect"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/lucabecchetti/swiftmultiselect.git", :tag => "#{s.version}"}

# 7
s.framework = "UIKit"

# 8
s.source_files = "SwiftMultiSelect/*.swift"
s.resource = "SwiftMultiSelect/Assets/*.*"

end
