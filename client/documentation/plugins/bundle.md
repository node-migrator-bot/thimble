### Bundle ###

Bundle adds order to your chaotic asset structure. Bundle takes all `script`, `style`, and `link` tags and bundle them into one `script` tag and one `style` tag. The `script` tag will be placed at the bottom of the `body`, while the `style` tag will be appended to the `head`. 

Bundle is often used as a preliminary step in the build process before pulling out these assets and minifying them.

Bundle will skip assets that contain `http://` as they often link to external CDNs.

The bundle plugin is part of the build script included in thimble and while developing, you probably will not need to use this plugin.

> **Note:** Make sure your script tags contain the attribute, `type = "text/javascript"`. Thimble needs this to differentiate between templates and scripts.