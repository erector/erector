class Index < Erector::Widget
  def render
    html do
      head do
        title do
          text 'Erector'
        end
      end
      body do
        style do
          text 'img { margin-right: 3em; }'
        end
        img :src => 'erector.jpg', :align => 'left'
        h1 do
          text 'Erector'
        end
        ul do
          li do
            a :href => 'rdoc' do
              text 'Documentation'
            end
          end
          li do
            a :href => 'http://rubyforge.org/projects/erector/' do
              text 'RubyForge Project'
            end
          end
          li do
            a :href => 'http://rubyforge.org/scm/?group_id=4797' do
              text 'Subversion'
            end
          end
          li do
            a :href => 'http://rubyforge.org/frs/?group_id=4797' do
              text 'Download'
            end
          end
        end
      end
    end
  end
end
