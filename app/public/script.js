$(function() {
  createPieChart = function(targetSelecter , data) {
    c3.generate({
      // グラグを表示するセレクタ
      bindto: targetSelecter,
      // グラフに表示するデータ
      data: {
        columns: data,
        type: 'pie',
      },
    });
  };
  var data = JSON.parse($('#json').text());
  createPieChart('#chart' , data);
});
