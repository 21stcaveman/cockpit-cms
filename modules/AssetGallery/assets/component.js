App.Utils.renderer.assetgallery = function(v, field) {
  var viewMode = field.options && field.options.viewMode || "tooltip";

  var assets = Array.isArray(v) ? v : [v];
  var cnt = assets.length;
  var output = "";
  var items = [];

  if (viewMode === 'tooltip') {
    assets.forEach(function(asset) {
      items.push(asset.display || asset.link || "n/a")
    });
    output = '<span class="uk-badge" title="'+items.join(', ')+'" data-uk-tooltip>'+(cnt+(cnt == 1 ? ' Link' : ' Links'))+'</span>';
  } else {
    assets.forEach(function(asset, idx) {
      if (asset.display && asset.link && asset._id) {
        var url = App.route('/'+link.link+'/'+link._id);
        assets.push('<a target="_blank" class="uk-text-small uk-button-small" href="'+url+'">'+link.display+'</a>');
      } else {
        assets.push("")
      }
    });
    output = assets.join("<br/>");
  }

  return output;
};
