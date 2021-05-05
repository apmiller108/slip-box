function ready (callback) {
  if (document.readyState != 'loading') {
    callback();
  } else {
    document.addEventListener('DOMContentLoaded', callback);
  };
};

ready(function() {
  document.querySelectorAll('#table-of-contents a').forEach(function(node) {
    var href = "#" + node.textContent.toLowerCase().replace(/\s/g, '-');
    node.setAttribute('href', href);
  });

  // Make sure the filter in initialized before trigging clicks
  UIkit.filter('#tag-filter-component');

  var url = new URL(window.location.href);
  var params = new URLSearchParams(url.search);
  var tag = params.get('tag');

  if (tag) {
    var filterId = '#filter-' + tag;
    document.querySelector(filterId).click();
  }
});
