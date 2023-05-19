$LOAD_PATH << File.expand_path('lib', __dir__)

require 'net/http'
require 'nokogiri'
require 'uri'

require 'pqa'
require 'pqa/answer'
require 'pqa/answer_response'
require 'pqa/mock_api_server'
require 'pqa/question'
require 'pqa/xml_decoder'
require 'pqa/xml_encoder'
require 'xml_extractor'

run PQA::MockApiServer
