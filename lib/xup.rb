# coding: utf-8

$KCODE = 'u'
class Xup < String

  def to_html
    split(/\n\n+/m).map do |block|
      head, *tail = block.split(' ')
      case head
      when /\A(={1,4})/
        level = $1.length
        "<h#{level}>#{tail.join(' ')}</h#{level}>"
      when /\A(\*|\#)/
        type = $1 == '*' ? 'ul' : 'ol'
        items = tail.join(' ').split($1).map {|i| "<li>#{i.strip}</li>" }
        "<#{type}>#{items.join("\n")}</#{type}>"
      else
        "<p>#{block.strip}</p>"
      end
    end.join("\n\n") + "\n"
  end

end
