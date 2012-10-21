require 'log/utils'

class RailsConsoleLogger

  NEW_LINE = "\r\n"

  def self.log(severity, message, context, events, metadata)
    text = build_log_text(severity, message, context, events, metadata)

    logger = ::Rails.logger
    begin
      logger.send(severity.to_s, text)
    rescue
      logger.info(text) # chosen severity might not exist for file logger
    end
  end

  private

  def self.build_log_text(severity, message, context, events, metadata)
    lines = []
    lines.push("======= #{severity.to_s.capitalize} =======")
    lines.push("## Message: #{Log::Utils.prepare_message(message)}")
    lines.push("##")

    lines.push("## Events:")
    events.each do |event|
      lines.push("##   #{event[:name]}: #{event[:data]}")
    end
    lines.push("##")

    lines.push("## Context:")
    context.each do |item|
      lines.push("##   #{item[0]}: #{item[1].inspect}")
    end
    lines.push("##")

    lines.push("## Metadata:")
    metadata.each do |item|
      lines.push("##   #{item[0]}: #{item[1].inspect}")
    end

    lines.push("========#{'=' * severity.to_s.length}========")

    text = "#{NEW_LINE*2}"
    text += "#{lines.join(NEW_LINE)}"
    text += "#{NEW_LINE*2}"
  end
end