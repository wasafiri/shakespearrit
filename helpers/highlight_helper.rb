module HighlightHelper
  def highlight(text, term)
    regex = Regexp.new("(?i)(#{Regexp.escape(term)})")
    # Escape the entire text to prevent XSS, then insert <mark> tags for the term
    escaped_text = ERB::Util.html_escape(text)
    highlighted_text = escaped_text.gsub(regex, '<mark>\1</mark>')
    highlighted_text
  end
end
