require 'rouge'
require 'fileutils'
require 'digest/md5'

PYGMENTS_CACHE_DIR = File.expand_path('../../.pygments-cache', __FILE__)
FileUtils.mkdir_p(PYGMENTS_CACHE_DIR)

module HighlightCode
  def self.highlight(str, lang)
    lang = 'ruby' if lang == 'ru'
    lang = 'objc' if lang == 'm'
    lang = 'perl' if lang == 'pl'
    lang = 'yaml' if lang == 'yml'
    str = pygments(str, lang).match(/<pre>(.+)<\/pre>/m)[1].to_s.gsub(/ *$/, '') #strip out divs <div class="highlight">
    tableize_code(str, lang)
  end

  def self.pygments(code, lang)
    if defined?(PYGMENTS_CACHE_DIR)
      path = File.join(PYGMENTS_CACHE_DIR, "#{lang}-#{Digest::MD5.hexdigest(code)}.html")
      if File.exist?(path)
        highlighted_code = File.read(path)
      else
        highlighted_code = rouge_highlight(code, lang)
        File.open(path, 'w') {|f| f.print(highlighted_code) }
      end
    else
      highlighted_code = rouge_highlight(code, lang)
    end
    highlighted_code
  end

  # Highlight with Rouge (pure Ruby), emitting the same
  # <div class="highlight"><pre>...</pre></div> shape the old Pygments
  # formatter produced, so downstream tableize_code still works.
  def self.rouge_highlight(code, lang)
    lexer = Rouge::Lexer.find_fancy(lang, code) || Rouge::Lexers::PlainText
    inner = Rouge::Formatters::HTML.new.format(lexer.lex(code))
    "<div class=\"highlight\"><pre>#{inner}</pre></div>"
  end
  def self.tableize_code (str, lang = '')
    table = '<div class="highlight"><table><tr><td class="gutter"><pre class="line-numbers">'
    code = ''
    str.lines.each_with_index do |line,index|
      table += "<span class='line-number'>#{index+1}</span>\n"
      code  += "<span class='line'>#{line}</span>"
    end
    table += "</pre></td><td class='code'><pre><code class='#{lang}'>#{code}</code></pre></td></tr></table></div>"
  end
end
