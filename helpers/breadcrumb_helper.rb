module BreadcrumbHelper
    def breadcrumb_trail
      links = []
      links << ['Home', '/']
      
      case request.path_info
      when /^\/plays\/(\d+)\/acts\/(\d+)\/scenes\/(\d+)\/speeches\/(\d+)/
        play = Play[$1]
        act = Act[$2]
        scene = Scene[$3]
        speech = Speech[$4]
        
        links << ['Plays', '/plays']
        links << [play.title, "/plays/#{play.id}"]
        links << ["Act #{act.act_number}", "/plays/#{play.id}/acts/#{act.id}"]
        links << ["Scene #{scene.scene_number}", "/plays/#{play.id}/acts/#{act.id}/scenes/#{scene.id}"]
        links << ["#{speech.speaker_name}'s Speech", "/plays/#{play.id}/acts/#{act.id}/scenes/#{scene.id}/speeches/#{speech.id}"]
      when /^\/plays\/(\d+)\/acts\/(\d+)\/scenes\/(\d+)/
        play = Play[$1]
        act = Act[$2]
        scene = Scene[$3]
        
        links << ['Plays', '/plays']
        links << [play.title, "/plays/#{play.id}"]
        links << ["Act #{act.act_number}", "/plays/#{play.id}/acts/#{act.id}"]
        links << ["Scene #{scene.scene_number}", ""]
      when /^\/plays\/(\d+)\/acts\/(\d+)/
        play = Play[$1]
        act = Act[$2]
        
        links << ['Plays', '/plays']
        links << [play.title, "/plays/#{play.id}"]
        links << ["Act #{act.act_number}", ""]
      when /^\/plays\/(\d+)/
        play = Play[$1]
        links << ['Plays', '/plays']
        links << [play.title, ""]
      when /^\/plays/
        links << ['Plays', ""]
      end
      
      render_breadcrumbs(links)
    end
    
    private
    
    def render_breadcrumbs(links)
      <<-HTML
      <nav aria-label="Breadcrumb navigation" class="breadcrumbs">
        <ol role="list" class="breadcrumbs-list">
          #{links.map.with_index do |(text, url), index|
            is_last = index == links.length - 1
            <<-LI
            <li class="breadcrumb-item#{' current' if is_last}" 
                #{is_last ? 'aria-current="page"' : ''}>
              #{url.empty? ? text : "<a href=\"#{url}\">#{text}</a>"}
              #{is_last ? '' : '<span aria-hidden="true"> › </span>'}
            </li>
            LI
          end.join}
        </ol>
      </nav>
      HTML
    end
end