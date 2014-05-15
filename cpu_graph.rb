#!/usr/bin/ruby

def read_file(f)
  data = []
  i=0
  text = File.open(f).read
  text.gsub!(/\r\n?/, "\n")
  name = ''
  score = 0
  price = ''
  text.each_line do |line|
    line.gsub!(/\n/, '')
    line.gsub!(/\s*$/, '')
    name = line if i==0
    score = Integer(line.gsub(/,/, '')) if i==1
    begin
      price = Float(line.gsub(/[,\$NA\*]/, '')) if i==2
    rescue
      raise "Cannot parse price from: #{line}, aka #{ line.gsub(/[,\$NA\*]/, '') }" unless line.include?('NA')
      price = -1
    end
    i = (i+1) % 3
    if (i==0) then
      data.push({"name" => name,
                 "score" => score,
                 "price" => price}) if (price>45)
    end
  end
  return data
end

single_f = ARGV[0]
multi_f = ARGV[1]

single = read_file(single_f)
multi = read_file(multi_f)

single.sort! { |a,b| a["price"] <=> b["price"] }
multi.sort! { |a,b| a["price"] <=> b["price"] }

puts <<-eos
  <html>
  <head>
  <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.3/themes/smoothness/jquery-ui.css" />
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.3/jquery-ui.js"></script>
  <style>
    * { margin:0; padding:0; font-family:Arial; }
    body { background-color: #222; }
    .label {
      position:absolute;
      font-size: 10px;
      color: #999;
    }
    .intel {
      position:absolute;
      width:6px;
      height:6px;
      background-color:rgba(64,64,255,0.3);
      border: 1px solid rgba(64,64,255, 0.6);
    }
    .amd {
      position:absolute;
      width:6px;
      height:6px;
      background-color:rgba(255,64,64,0.3);
      border: 1px solid rgba(255,64,64, 0.6);
    }
    #search_box {
      position:absolute;
      top:5px;
      left:360px;
      font-size:13px;
      width:500px;
    }
    #search {
      font-size:13px;
      background-color: #444;
      border: 1px solid #ccc;
      color: #aaa;
      width:350px;
      padding: 2px;
    }
    #legend {
      margin-top: 5px;
    }
    #legend span {
      margin-right:3px;
    }
  </style>
  <body>
  <div id="search_box">
  <span style="color:#999">Search: </span><input id='search' type="text" name="search" placeholder="Search"/><br>
    <div id="legend"/><span style="color:#3333ee">Intel</span><span style="color:#ee3333">AMD</span></div>
  </div>
  </body>
  <script type='text/javascript'>

  $(function () {
        $(document).tooltip({
            content: function () {
                var item = this;
                val = $(this).prop('title');
                var other;
                if (item.id.indexOf('s_')==0) {
                  other = document.getElementById((item.id+"").replace(/^s_/, 'm_'));
                  try {
                    var ss = $(other).prop('title').match(/Score:\\s*(\\d+)/)[1];
                    val = val.replace(/Score:\\s+(\\d+)/, function(m, v1) { return "Score: single="+v1+", multi="+ss; });
                  } catch(e) { }
                } else {
                  other = document.getElementById((item.id+"").replace(/^m_/, 's_'));
                  try {
                    var ss = $(other).prop('title').match(/Score:\\s*(\\d+)/)[1];
                    val = val.replace(/Score:\\s+(\\d+)/, function(m, v1) { return "Score: single="+ss+", multi="+v1; });
                  } catch(e) { }
                }
                return val;
          }
      });
  });

var search_colors = ["#00ff00", "#ff9922", "#ddff22", "#9C3FED", "#00dddd", "#F16C99"];
if (window.location.hash.length>0) {
  $("#search")[0].value = unescape(window.location.hash.substr(1));
  setTimeout(update_search, 100);
}
$("#search").on('input', update_search);

function update_search(e) {
  //console.log(e.target.value);

  window.location.hash = escape($("#search")[0].value);

  var arr = $("#search")[0].value.split(",");

  var leg = '<span style="color:#3333ee">Intel</span><span style="color:#ee3333">AMD</span>';

  for (var i=0; i<arr.length; i++) {
    var color = i < search_colors.length ? search_colors[i] : '#'+(Math.floor(Math.random()*0xffffff)).toString(16);
    var term = arr[i].replace(/^\\s+/, '').toLowerCase();
    if (term.length==0 && i>0) continue;

    leg += '<span style="color:'+color+'">'+term+'</span>';

    $(".cpu").each(function(idx, item) {
      if (term.length>0 && item.name.toLowerCase().indexOf(term)>=0) {
        highlight(item, true, color);
      } else if (i==0) {
        unhighlight(item, true);
      }
    });

    $('#legend').html(leg);
  }
}

function highlight(item, via_search, with_color) {
    if (item.highlighted) return;
    if (item.via_search && via_search==undefined) return;
    item.via_search = via_search;
    item.highlighted = true;
    item.style.border = '2px solid #000000';
    item.style.backgroundColor = with_color!=undefined ? with_color : '#fff';
    item.style.zIndex = '2';
    item.style.boxShadow = '0 0 10px #000';
    var other;
    if (item.id.indexOf('s_')==0) {
      other = document.getElementById((item.id+"").replace(/^s_/, 'm_'));
    } else {
      other = document.getElementById((item.id+"").replace(/^m_/, 's_'));
    }
    if (other) {
      other.highlighted = true;
      other.via_search = via_search;
      other.style.border = '2px solid #000000';
      other.style.backgroundColor = with_color!=undefined ? with_color : '#fff';
      other.style.zIndex = '2';
      other.style.boxShadow = '0 0 10px #000';
    }
  }
  function unhighlight(item, via_search) {
    if (!item.highlighted) return;
    if (item.via_search && via_search==undefined) return;
    item.via_search = false;
    item.highlighted = false;
    item.style.border = '';
    item.style.backgroundColor = '';
    item.style.zIndex = '';
    item.style.boxShadow = '';
    var other;
    if (item.id.indexOf('s_')==0) {
      other = document.getElementById((item.id+"").replace(/^s_/, 'm_'));
    } else {
      other = document.getElementById((item.id+"").replace(/^m_/, 's_'));
    }
    if (other) {
      other.highlighted = false;
      other.via_search = false;
      other.style.border = '';
      other.style.backgroundColor = '';
      other.style.zIndex = '';
      other.style.boxShadow = '';
    }
  }
eos


def draw_graph(height, ymin, label, data, id_prefix, yfactor)
  xoff = 80

  data.each { |data|
    color = (data["name"].include?('Intel')) ? "'rgba(0, 0, 255, .5)'" : "'rgba(255, 0, 0, .5)'"
    puts "d = document.createElement('div');"
    puts "d.className = '#{ (data["name"].include?('Intel')) ? "intel" : "amd" } cpu';"
    puts "d.id = '#{ id_prefix+data["name"].gsub(/\s/, '') }';"
    puts "d.style.top = '#{ (ymin + height - data["score"]/(yfactor/height)).to_i - 3}px';"
    puts "d.style.left = '#{ ( 130*Math.log(data["price"]-40)).to_i - xoff }px';"
    puts "d.title = \"#{ data["name"] }<br>Score: #{ data["score"] }<br>Price: $#{ data["price"] }\";"
    puts "d.name = \"#{ data["name"] }\";"
    puts "d.onmouseover = function() { highlight(this) };"
    puts "d.onmouseout = function() { unhighlight(this) };"
    puts "document.body.appendChild(d);"
  }

  puts "d = document.createElement('div');"
  puts "d.className = 'label';"
  puts "d.style.top = '#{ymin}px';"
  puts "d.style.height = '#{ height.to_i }px';"
  puts "d.style.left = '20px';"
  puts "d.style.borderRight = '1px solid #555';"
  puts "d.innerHTML = '<span style=\"position:relative;top:#{(height/2 - 5).to_i}px\">Score</span>';"
  puts "document.body.appendChild(d);"

  i=50
  while (i<2000) do
    puts "d = document.createElement('div');"
    puts "d.className = 'label';"
    puts "d.style.top = '#{ymin+50}px';"
    puts "d.style.height = '#{ (height-50).to_i }px';"
    puts "d.style.left = '#{ ( 130*Math.log( i -40)).to_i - xoff + 4 }px';"
    puts "d.style.borderRight = '1px solid #aaa';"
    puts "d.innerHTML = '<span style=\"position:absolute;top:0px;left:10px\">$#{i}</span>';"
    puts "document.body.appendChild(d);"
    i *= 2
  end

  puts "d = document.createElement('div');"
  puts "d.className = 'label';"
  puts "d.style.top = '#{(ymin+height).to_i}px';"
  puts "d.style.width = '900px';"
  puts "d.style.left = '40px';"
  puts "d.style.borderTop = '1px solid #555';"
  puts "d.style.textAlign = 'center';"
  puts "d.innerHTML = 'Price';"
  puts "document.body.appendChild(d);"
   
  puts "d = document.createElement('div');"
  puts "d.className = 'label';"
  puts "d.style.top = '#{ymin+5}px';"
  puts "d.style.fontSize = '15px';"
  puts "d.style.left = '60px';"
  puts "d.innerHTML = '#{label}';"
  puts "document.body.appendChild(d);"
end

draw_graph(400,30,'Single-Threaded Benchmarks',single,'s_',3000)
draw_graph(400,470,'Multi-Threaded Benchmarks',multi,'m_',20000)

puts "</script></html>"
