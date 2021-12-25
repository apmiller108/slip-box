function ready (callback) {
  if (document.readyState != 'loading') {
    callback();
  } else {
    document.addEventListener('DOMContentLoaded', callback);
  };
};

ready(function() {
  // Sets the href property of the TOC links.
  document.querySelectorAll('#table-of-contents a').forEach(function(node) {
    var href = "#" + node.textContent.toLowerCase().replace(/\s/g, '-');
    node.setAttribute('href', href);
  });

  // Make sure the filter in initialized before trigging clicks
  UIkit.filter('#tag-filter-component');

  // If there's a 'tag' query param, find the link and trigger a click to filter the posts
  var url = new URL(window.location.href);
  var params = new URLSearchParams(url.search);
  var tag = params.get('tag');

  if (tag) {
    var filterId = '#filter-' + tag;
    document.querySelector(filterId).click();
  }

  // Search

  var searchIndex;

  fetch('/js/search-index.json')
    .then(response => response.json())
    .then((data) => {
      searchIndex = lunr.Index.load(data)
      console.log(searchIndex.search('stacking'));
    });
});
