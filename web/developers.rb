dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Developers < Page

  def render_body
    
    p "Want to help develop Erector? Here's what to do."

    h2 "Check out project from rubyforge:"
    pre "svn co svn+ssh://developername@rubyforge.org/var/svn/erector/trunk erector"

    h2 "Install gems:"
    pre "sudo gem install rake rails rspec rubyforge hpricot treetop"

    h2 "Run specs:"
    pre "rake"

    h2 "Check out the available rake tasks:"
    pre "rake -T"

    h2 "Sign up for the erector-devel mailing list:"
    a("erector-devel mailing list", :href => "http://rubyforge.org/mailman/listinfo/erector-devel")

    h2 "Join the Lighthouse project:"
    url "mailto:erector-devel@rubyforge.org"
    text " with your Lighthouse account name, then visit "
    url "http://erector.lighthouseapp.com"

    h2 "Versioning and Release Policy"
    ul do
      li "Versions are of the form major.minor.tiny"
      li "Tiny revisions fix bugs or documentation"
      li "Tiny revisions are roughly equal to the svn revision number when they were made"
      li "Minor revisions add API calls, or change behavior"
      li "Minor revisions may also remove API calls, but these must be clearly announced in History.txt, with instructions on how to migrate "
      li "Major revisions are about marketing more than technical needs. We will stay in major version 0 until we're happy taking the \"alpha\" label off it. And if we ever do a major overhaul of the API, especially one that breaks backwards compatibility, we will probably want to increment the major version."
      li "We will not be shy about incrementing version numbers -- if we end up going to version 0.943.67454 then so be it."
      li "Developers should attempt to add lines in History.txt to reflect their checkins. These should reflect feature-level changes, not just one line per checkin. The top section of History.txt is used as the Release Notes by the \"rake publish\" task and will appear on the RubyForge file page."
    end

    h2 "How to push a release"
    ol do
      li "Pick a version number. For the build number run 'svn info | grep Revision'"
      li "Look at History.txt and make sure the release notes are up to date. Put the version number on the top line (after the \"==\")."
      li "Put the version number in erector.rb as Erector::VERSION."
      li "Check in with a comment, e.g. 'svn ci -m \"release 1.2.3\"'"
      li "Run 'rake release VERSION=1.2.3'. (The parameter is to confirm you're releasing the version you intend to.)"
      li "Run 'rake publish_docs web publish_web' cause the docs and site need to be updated, at least with the new version number."
      li "Immediately go into History.txt and make a new section at the top. Since we won't yet know what the next version will be called, the new section will be noted by a single \"==\" at the top of the file."
    end
  end

end
