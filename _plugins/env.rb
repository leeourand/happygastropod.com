module HappyGastropod
  class DisqusDeveloper < Liquid::Tag

    def render(context)
      ENV['JEKYLL_DEPLOY'] == 'true' ? '' : 'var disqus_developer = 1;'
    end
    
  end
end

Liquid::Template.register_tag 'disqus_developer', HappyGastropod::DisqusDeveloper