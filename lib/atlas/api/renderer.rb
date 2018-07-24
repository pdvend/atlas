# frozen_string_literal: true

module Renderer
  require_relative 'renderer/base_renderer'
  require_relative 'renderer/json_renderer'
  require_relative 'renderer/pdf_renderer'
  require_relative 'renderer/stream_renderer'
  require_relative 'renderer/xml_renderer'
  require_relative 'renderer/zip_renderer'
end
