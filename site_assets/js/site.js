function ready (callback) {
  if (document.readyState != 'loading') {
    callback();
  } else {
    document.addEventListener('DOMContentLoaded', callback);
  };
};

ready(function() {
  // Sets the href property of the TOC links. Normalize to downcase removing the
  // non-alphanumeric characters. This is how the anchor links are built in publish.org
  document.querySelectorAll('#table-of-contents a').forEach(function(node) {
    var href = "#" + node.textContent.toLowerCase()
                                     .replace(/[\W_]/g, '');
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
  var searchForm = document.querySelector('#search-form');
  var searchResults;
  var searchResultsModal = document.querySelector('#search-results');

  // Fetch and load the pre-built search index
  fetch('/js/search-index.json')
    .then(response => response.json())
    .then((data) => {
      searchIndex = lunr.Index.load(data)
    });

  var UIkitSearchModal = UIkit.modal(searchResultsModal);

  searchResultsModal.addEventListener('beforeshow', function(e) {
    var bodyElem = e.target.querySelector('#search-results-body');

    // Clear previous search results
    bodyElem.innerHTML = '';

    // Add search results
    searchResults.forEach(function(result) {
      var path = result.ref.replaceAll(/public|index\.html/g, "");
      var link = document.createElement("a");
      link.href = path;
      link.textContent = path
      bodyElem.appendChild(link);
    });
  });

  searchForm.addEventListener('submit', function(e) {
    e.preventDefault();
    var searchTerm = e.target.querySelector('input').value;
    if (searchTerm) {
      searchResults = searchIndex.search(searchTerm)
      UIkitSearchModal.show();
    };
  });
});
