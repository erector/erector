dir = File.dirname(__FILE__)
require "#{dir}/page"
require "#{dir}/sidebar"

class Developers < Page

  def render_body
    
    p "Want to help develop Erector? Here's what to do."

    h2 "Check out project from rubyforge:"
    p "If you prefer to use git instead of svn, see below."
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
    
    h2 "Read-only access using git"
    p "First, install git.  Then download erector using git:"
    pre "git clone git://github.com/pivotal/erector.git"
    p "Generate a diff between what you have edited and what you have run git add on:"
    pre "git diff"
    p "Generate a diff between what you have run git add on and locally committed:"
    pre "git diff --cached"
    p "Commit locally (into your .git directory):"
    pre "git commit -a"
    p "You can update from the erector repository at github with:"
    pre "git pull"
    p "However, since you have checked out git read-only, you cannot push back your changes with:"
    pre "git push"
    p "Instead, mail a diff to the mailing list."

    h2 "Read/write access using git-svn"
    p "The following instructions assume you have been listed as a collaborator on the github pivotal erector project."
    p "First, install git and git-svn.  Then:"
    pre "git svn clone svn+ssh://developername@rubyforge.org/var/svn/erector/trunk erector"
    p "This will take a while as it checks out the old revisions from subversion."

    p "When you are ready to make your changes part of the master repository (which is still subversion instead of git), do the following:"
    pre <<END
git commit -a
git svn dcommit
END
    p "When someone makes a change to the subversion tree, run:"
    pre "git svn rebase"
    
    p %Q{These instructions do not cover pushing your git revisions 
    to the github pivotal erector repository, or pulling from there.  
    If someone has successfully done this, please let us know via 
    the mailing list, or update these instructions.}
    
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
      li %q{Look at History.txt and make sure the release notes are up to date. Put the version number on the top line (after the "==").}
      li "Put the version number in lib/erector/version.rb as Erector::VERSION."
      li %q{Check in with a comment, e.g. 'svn ci -m "release 1.2.3"'}
      li %q{Run 'rake package' so that you can see whether the gem generation seems to work locally before proceeding to try to upload it to rubyforge (if you skip this step, the package will be generated when you run rake release)}
      li "If you haven't done so before, run 'rubyforge setup' and 'rubyforge config' (for more details on these steps, see README.txt in the rubyforge gem)"
      li "Run 'rake release VERSION=1.2.3'. (The parameter is to confirm you're releasing the version you intend to.)"
      li "Run 'rake publish_docs web publish_web' cause the docs and site need to be updated, at least with the new version number."
      li %q{Immediately go into History.txt and make a new section at the top. Since we won't yet know what the next version will be called, the new section will be noted by a single "==" at the top of the file.}
      li do
        text "Send email to "
        a("erector-devel mailing list", :href => "mailto:erector-devel@rubyforge.org")
        text " announcing the new release."
      end
    end
  end

end
