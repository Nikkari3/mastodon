# frozen_string_literal: true

class Sanitize
  module Config
    HTTP_PROTOCOLS ||= ['http', 'https', :relative].freeze

    CLASS_WHITELIST_TRANSFORMER = lambda do |env|
      node = env[:node]
      class_list = node['class']&.split(/[\t\n\f\r ]/)

      return unless class_list

      class_list.keep_if do |e|
        next true if e =~ /^(h|p|u|dt|e)-/ # microformats classes
        next true if e =~ /^(mention|hashtag)$/ # semantic classes
        next true if e =~ /^(ellipsis|invisible)$/ # link formatting classes
        next true if e =~ /^fa$/ # font awesome
        next true if e =~ /^fa-spin$/ # font awesome
        next true if e =~ /^pulse-loading$/ # font awesome
        next true if e =~ /^fa-flip-(horizontal|vertical)$/ # font awesome
        next true if e =~ /^fa-(2x|3x|4x|5x)$/ # font awesome
# もともとreturnだったところをnextにした。 /^fa$/を含むそれより下はBBcodeなので変更いらないかも
      end

      node['class'] = class_list.join(' ')
    end

    MASTODON_STRICT ||= freeze_config(
      elements: %w(p br span a),

      attributes: {
        'a'    => %w(href rel class),
        'span' => %w(class),
      },

      add_attributes: {
        'a' => {
          'rel' => 'nofollow noopener',
          'target' => '_blank',
        },
      },

      protocols: {
        'a' => { 'href' => HTTP_PROTOCOLS },
      },

      transformers: [
        CLASS_WHITELIST_TRANSFORMER,
      ]
    )

    MASTODON_OEMBED ||= freeze_config merge(
      RELAXED,
      elements: RELAXED[:elements] + %w(audio embed iframe source video),

      attributes: merge(
        RELAXED[:attributes],
        'audio'  => %w(controls),
        'embed'  => %w(height src type width),
        'iframe' => %w(allowfullscreen frameborder height scrolling src width),
        'source' => %w(src type),
        'video'  => %w(controls height loop width),
        'div'    => [:data]
      ),

      protocols: merge(
        RELAXED[:protocols],
        'embed'  => { 'src' => HTTP_PROTOCOLS },
        'iframe' => { 'src' => HTTP_PROTOCOLS },
        'source' => { 'src' => HTTP_PROTOCOLS }
      )
    )
  end
end
