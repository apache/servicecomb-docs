# coding: utf-8
from __future__ import absolute_import, unicode_literals

import os
import logging
from mkdocs import utils
from mkdocs.plugins import BasePlugin
from mkdocs.config import config_options

log = logging.getLogger(__name__)
base_path = os.path.dirname(os.path.abspath(__file__))

class SearchPlugin(BasePlugin):
    def on_config(self, config, **kwargs):
        if 'search/main.js' not in config['extra_javascript']:
                config['extra_javascript'].append('search/main.js')
        return config

    def on_post_build(self, config, **kwargs):
        output_base_path = os.path.join(config['site_dir'], 'search')
        input_base_path = os.path.join(base_path, 'search')

        to_path = os.path.join(output_base_path, 'main.js')
        from_path = os.path.join(input_base_path, 'main.js')
        utils.copy_file(from_path, to_path)
