
This script builds a list of all the ids of all the objects in the met's online collection, using [scrAPI.org][].

It is how we are dumping a big list of images. If you are interested in a USB drive with the images on them, please contact us!

#### Howto

  list_ids.coffee will dump every id found (that has an image) from scrapi.org and dump it to `data/ids.json`
  grab_paths.coffee will read those ids and grab the local paths from Don's web services and pipe it to `data/paths.json`
  download_images.coffee will copy every path to `images/{id}.jpg` (usually jpg)

#### Guidelines

  The code is [CC0][], but if you do anything interesting with the data, it would be nice to give attribution to The Metropolitan Museum of Art. If you do anything interesting with the code, it would be nice to give attribution and contribute back any modifications or improvements.

[CC0]: http://creativecommons.org/publicdomain/zero/1.0
[scrAPI.org]: http://scrAPI.org