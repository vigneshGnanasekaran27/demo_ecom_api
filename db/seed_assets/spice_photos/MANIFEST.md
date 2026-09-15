# Spice product photo manifest

All sourced from Wikimedia Commons (free-licensed, stable direct URLs), downloaded via the
Commons `imageinfo` API. Used as real dummy product photography for the seeded spice catalog
(`db/seeds.rb`) — every image here was visually inspected before use; several initial candidates
were rejected and are listed at the bottom.

| filename | subject | Commons page | license |
|---|---|---|---|
| whole-red-chillies.jpg | whole dried red chillies | https://commons.wikimedia.org/wiki/File:Dried_Capsicum_annuum-Red_Chilli_Pepper_on_Nanglo.jpg | CC BY-SA 4.0 |
| green-cardamom.jpg | green cardamom pods | https://commons.wikimedia.org/wiki/File:Green_Cardamom_Pods.jpg | CC0 |
| cinnamon-sticks.jpg | cinnamon sticks | https://commons.wikimedia.org/wiki/File:Cinnamon_sticks_(1).jpg | CC0 |
| black-peppercorns.jpg | black peppercorns | https://commons.wikimedia.org/wiki/File:Tellicherry_Black_Peppercorns.jpg | CC0 |
| whole-cloves.jpg | whole cloves | https://commons.wikimedia.org/wiki/File:Cloves_whole.JPG | Public domain |
| star-anise.jpg | star anise | https://commons.wikimedia.org/wiki/File:Star_anise_seeds.jpg | CC BY 4.0 |
| turmeric-powder.jpg | turmeric powder on a spoon | https://commons.wikimedia.org/wiki/File:Turmeric_Powder_on_a_Spoon_-_Black_Background.jpg | CC BY 2.0 |
| red-chilli-powder.jpg | red chilli powder in a bowl | https://commons.wikimedia.org/wiki/File:Redchilipepperpowder.JPG | CC BY-SA 3.0 |
| cumin-seeds.jpg | cumin (jeera) seeds close-up | https://commons.wikimedia.org/wiki/File:Jeera_Seeds_Closeup.JPG | CC BY-SA 3.0 |
| ground-black-pepper.jpg | ground black pepper | https://commons.wikimedia.org/wiki/File:Ground_black_pepper.jpg | CC BY-SA 4.0 |
| sambar-powder.jpg | loose masala powder in a bowl | https://commons.wikimedia.org/wiki/File:Sambar_powder.jpg | CC BY-SA 4.0 |
| masala-chai-spices.jpg | chai with whole spices | https://commons.wikimedia.org/wiki/File:Masala_Chai.JPG | Public domain |
| detail-spices-kitchen.jpg | masala dabba (spice box), overhead | https://commons.wikimedia.org/wiki/File:Spices_in_an_Indian_kitchen.JPG | CC BY-SA 3.0 |
| detail-spices-assortment.jpg | masala dabba (spice box), overhead | https://commons.wikimedia.org/wiki/File:Indianspicesherbs.jpg | CC BY 2.0 |

14 images, all verified as valid, unbranded JPEGs before use.

## Rejected candidates (do not reuse without re-checking)
Wikimedia Commons search results for "X powder"-style queries repeatedly surfaced **real
third-party brands' actual packaged-product photography**, not neutral stock shots — these were
caught only by opening and visually inspecting each image, not from filenames/descriptions alone:
- `garam-masala.jpg` (orig. `Garam_Masala_Powder_by_Chlorofeel_Groups.jpg`) — showed a real
  "Chlorofeel Food & Spices" package with the manufacturer's actual phone number/email/address.
- `coriander-powder.jpg` / `cumin-powder.jpg` / an earlier `red-chilli-powder.jpg` pick — all
  showed the same real brand's ("Quityfress") packaged product line.
- A "spice powder spoon macro" search result showed generic market ziplock bags with visible
  Chinese-language price/barcode stickers, not spice product photography.
- A "coriander seed macro" pick resolved to only a 226×135px thumbnail — too low-resolution to use.

Do not display real competitors' branded packaging as if it were this site's own product —
replaced each with a clean unbranded alternative (see table above) or, for chaat masala/tandoori
masala/biryani masala/rasam powder/pav bhaji masala/kitchen king masala — none of which had a
dedicated raw-powder product shot available (results were all cooked dishes) — the seed step
reuses the closest-fitting unbranded photo from this set instead of forcing a bad match.
