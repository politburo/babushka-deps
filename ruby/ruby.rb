dep "ruby 1.9 installed" do
  requires {
    on :ubuntu, 'ruby 1.9 installed and made default on ubuntu'
  }

end

dep 'ruby 1.9 installed and made default on ubuntu' do
  requires 'ruby1.9.managed'

  met? {
    grep "ruby -v" =~ /1.9/
  }
end