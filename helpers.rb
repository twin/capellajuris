# encoding:utf-8
helpers do
  def page_on_croatian(page)
    case page
    when 'index'; 'Početna'
    when 'o_nama'; 'O Nama'
    when 'slike'; 'Slike'
    when 'video'; 'Video'
    end
  end

  def current?(page)
    ('/' + page == request.path_info) or (page == 'index' and request.path_info == '/')
  end

  def form?(page)
    Dir['views/forms/*'].include? "views/forms/#{page}.haml"
  end

  def authenticate!(&block)
    if not User[:username => params[:username], :password => params[:password]]
      @error = 'Krivo korisničko ime ili lozinka.'
      haml "forms#{request.path_info}".to_sym
    else
      yield
    end
  end

  def log_in!
    session[:logged_in] = true
  end

  def log_out!
    session[:logged_in] = false
  end

  def logged_in?
    session[:logged_in]
  end

  def voice_to_cro(voice)
    case voice
    when 'S'; 'Soprani'
    when 'A'; 'Alti'
    when 'T'; 'Tenori'
    when 'B'; 'Basi'
    end
  end

  def string_to_id(string)
    string.downcase.delete(' ').gsub(/[ČĆčć]/, 'c').gsub(/[Šš]/, 's').gsub(/[Đđ]/, 'd').gsub(/[Žž]/, 'z')
  end

  def validate!(&block)
    if params[:title].empty? and params[:body].empty?
      request.path_info.include?('post') ? redirect(:/) : redirect(:o_nama)
    elsif params[:title].empty? or params[:body].empty?
      @error = "Naslov ili sadržaj je ostao prazan."
      if request.path_info.include? 'post'
        @post = Post.new(:title => params[:title], :body => params[:body])
        haml :'forms/post'
      else
        @content = Content.new(:title => params[:title], :body => params[:body])
        haml :'forms/content'
      end
    else
      yield
    end
  end
end

module Haml
  module Helpers
    def form_tag(attr, &block)
      if attr[:method] == 'get' or attr[:method] == 'post'
        haml_tag(:form, {action: attr[:action],
                         method: attr[:method],
                         id: attr[:id]}) { yield }
      else
        haml_tag(:form, {action: attr[:action],
                         method: 'post',
                         id: attr[:id]}) do
          haml_tag(:input, {type: 'hidden',
                            name: '_method',
                            value: attr[:method]}) { yield }
        end
      end
    end

    def button(attr)
      form_tag(action: attr[:action], method: attr[:method], :class => 'button', id: attr[:id]) do
        haml_tag :input, {type: 'submit', value: attr[:value]}
      end
    end

    def render_markdown(text)
      BlueCloth.new(text).to_html
    end
  end
end
