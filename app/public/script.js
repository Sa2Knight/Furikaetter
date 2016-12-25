$(function() {
  var createPieChart = function(targetSelecter , data) {
    c3.generate({
      bindto: targetSelecter,
      data: {
        columns: data,
        type: 'pie',
        order: null,
      },
    });
  };
  var data = JSON.parse($('#json').text());
  createPieChart('#chart' , data);
});
