$(function() {
  var createPieChart = function(targetSelecter , source) {
    var data = JSON.parse($(source).text());
    c3.generate({
      bindto: targetSelecter,
      data: {
        columns: data,
        type: 'pie',
        order: null,
      },
    });
  };
  createPieChart('#hash_rate' , '#hash_rate_json');
  createPieChart('#rep_rate' , '#rep_rate_json');
  createPieChart('#hash_used_rate' , '#hash_used_rate_json');
  createPieChart('#rep_target_rate' , '#rep_target_rate_json');
});
