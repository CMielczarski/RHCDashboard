import { LightningElement, api } from 'lwc';

import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import ChartJS from '@salesforce/resourceUrl/ChartJS';

export default class Rhcchart extends LightningElement {

    @api charttitle = "Accounts Without Activity";
    @api chart;
    @api chartLegend;
    @api chartdata
    @api chartList = [];

    chartJsInitialised = false;

    renderedCallback(){
        if(this.chartJsInitialised) {
            return;
            }
        this.chartJsInitialised = true;
    Promise.all([
        loadScript(this, ChartJS + '/Chartjs1.min.js'),
        loadStyle(this, ChartJS + '/Chartjs.css')
        ]);
        this.drawChart();
    }

    waiting() {
        this.spinner = true;
        }
 
    doneWaiting(){
        this.spinner = false;
        }
    
    createChart(){
        this.drawChart();
        }

    drawChart(){
        var charttitle = this.charttitle;
        let chartdata = {...this.chartdata};
        console.log('Chart Data rhcChart: ' + chartdata);
        var haschartdata = true;
        var arr = new Array();
    
        for(var i=0 ; i < chartdata.length; i++){
            if(chartdata[i].value == 0){
                arr.push(chartdata[i].value);
                }
            }
            
        if(chartdata.length == arr.length){
            haschartdata = false;
            }
            
        var segmentPercent = 0;
        // In case of Pie, Doughnut, PolarArea.
        if(chartdata.length > 0 && chartdata[0].value != null){
            var chartLegend = [];
            for(var i=0; i < chartdata.length; i++){
                // If color is null, set it.
                chartdata[i].legendLabel = chartdata[i].legendLabel;
                if(chartdata[i].color == null){
                    chartdata[i].color = chartdata[i].colorVal;
                    }
                segmentPercent = segmentPercent+chartdata[i].value;
                chartdata[i].text= 'dsd';
                console.log('====text=2=1==',chartdata[i].text);
                // If value is not set, exit.
                if(chartdata[i].value == null){
                    console.error("Chart data is corrupted. Required property 'chartdata[" + i + "].value' not found.");
                    return;
                    }
                if(haschartdata){
                    // Set chart legend.
                    if(chartdata[i].label != null && chartdata[i].label != ""){
                        chartLegend.push({
                            label : chartdata[i].legendLabel,
                            color : chartdata[i].color,
                            style : 'display: inline-flex; color:' + chartdata[i].color,
                            divstyle : 'width:15px; height:10px; margin-top: 4px; background-color:' + chartdata[i].color,
                            amount : chartdata[i].value
                            });
                        }
                    }
                }
            this.chartLegend = chartLegend;
            }
            // If chart already exists, we destroy it first and re-create to clean the state.
            var chart = this.chart;
            if (chart != null){
                chart.destroy();
                }
    
            // Draw chart.
            var chartType = 'Pie'; 
            
            var	canvas = document.querySelector("#chart");
            console.log('Canvas: ' + canvas);
            var ctx = canvas.getContext("2d");
          
            if (haschartdata) {
                
                Chart.types.Pie.extend({
                    name: "DoughnutAlt",
                    draw: function () {
    
                        Chart.types.Pie.prototype.draw.apply(this, arguments);
                        var radius = this.outerRadius;
                        var midX = canvas.width/2;
                        var midY = canvas.height/2;
                        var textSize = "14";
                        for(var i=0; i<this.segments.length; i++) {
    
                            ctx.fillStyle="black";
                                                                    
                            ctx.font= textSize+"px Verdana";
                            
                            // Get needed variables
                            var value = this.segments[i].value;
                            var startAngle = this.segments[i].startAngle;
                            var endAngle = this.segments[i].endAngle;
                            var middleAngle = startAngle + ((endAngle - startAngle)/2);
                            
                            // Compute text location
                            var posX = (radius/2) * Math.cos(middleAngle) + midX;
                            var posY = (radius/2) * Math.sin(middleAngle) + midY;
                            
                            // Text offside by middle
                            var w_offset = ctx.measureText(value).width/2;
                            var h_offset = textSize/4;
                            
                            
                            var segmentPercentageVal = (value * 100)/segmentPercent;
                            segmentPercentageVal = segmentPercentageVal.toFixed(1);
                            ctx.textAlign = "center"
                            ctx.textBaseline = "middle";
                            ctx.fillText(segmentPercentageVal+'%', (posX - w_offset), posY - h_offset);
                        }
                    }
                });
                
                new Chart(ctx).DoughnutAlt(chartdata, {
                    percentageInnerCutout: 1, animationEasing: "easeOutQuart"
                });
    
            }
            else {
                
                ctx.font = "20px Verdana";
                ctx.textAlign = "left";
                ctx.textBaseline = "middle";
                ctx.fillStyle = "grey";
                ctx.fillText("No data in chart.", 100, 100);
            }
            
            
            // Save chart instance and chart data so that we can refer them afterward. 
            // Ex. Those properties are refered when chart type is changed.
            this.chart = chart;
            this.chartdata = chartdata;
       
        }

        showTooltip(t, i){
            console.log('======hello===');
                "undefined" == typeof this.activeElements && (this.activeElements = []);
                var o = function(t) {
                    var i = !1;
                    return t.length !== this.activeElements.length ? i = !0 : (n(t, function(t, e) {
                        t !== this.activeElements[e] && (i = !0)
                    }, this), i)
                }.call(this, t);
                if (o || i) {
                    if (this.activeElements = t, this.draw(), this.options.customTooltips && this.options.customTooltips(!1), t.length > 0)
                        if (this.datasets && this.datasets.length > 1) {
                            for (var a, h, r = this.datasets.length - 1; r >= 0 && (a = this.datasets[r].points || this.datasets[r].bars || this.datasets[r].segments, h = l(a, t[0]), -1 === h); r--);
                            var c = [],
                                u = [],
                                d = function() {
                                    var t, i, e, n, o, a = [],
                                        l = [],
                                        r = [];
                                    return s.each(this.datasets, function(i) {
                                        t = i.points || i.bars || i.segments, t[h] && t[h].hasValue() && a.push(t[h])
                                    }), s.each(a, function(t) {
                                        l.push(t.x), r.push(t.y), c.push(s.template(this.options.multiTooltipTemplate, t)), u.push({
                                            fill: t._saved.fillColor || t.fillColor,
                                            stroke: t._saved.strokeColor || t.strokeColor
                                        })
                                    }, this), o = m(r), e = g(r), n = m(l), i = g(l), {
                                        x: n > this.chart.width / 2 ? n : i,
                                        y: (o + e) / 2
                                    }
                                }.call(this, h);
                            new e.MultiTooltip({
                                x: d.x,
                                y: d.y,
                                xPadding: this.options.tooltipXPadding,
                                yPadding: this.options.tooltipYPadding,
                                xOffset: this.options.tooltipXOffset,
                                fillColor: this.options.tooltipFillColor,
                                textColor: this.options.tooltipFontColor,
                                fontFamily: this.options.tooltipFontFamily,
                                fontStyle: this.options.tooltipFontStyle,
                                fontSize: this.options.tooltipFontSize,
                                titleTextColor: this.options.tooltipTitleFontColor,
                                titleFontFamily: this.options.tooltipTitleFontFamily,
                                titleFontStyle: this.options.tooltipTitleFontStyle,
                                titleFontSize: this.options.tooltipTitleFontSize,
                                cornerRadius: this.options.tooltipCornerRadius,
                                labels: c,
                                legendColors: u,
                                legendColorBackground: this.options.multiTooltipKeyBackground,
                                title: t[0].label,
                                chart: this.chart,
                                ctx: this.chart.ctx,
                                custom: this.options.customTooltips
                            }).draw()
                        } else n(t, function(t) {
                            var i = t.tooltipPosition();
                            new e.Tooltip({
                                x: Math.round(i.x),
                                y: Math.round(i.y),
                                xPadding: this.options.tooltipXPadding,
                                yPadding: this.options.tooltipYPadding,
                                fillColor: this.options.tooltipFillColor,
                                textColor: this.options.tooltipFontColor,
                                fontFamily: this.options.tooltipFontFamily,
                                fontStyle: this.options.tooltipFontStyle,
                                fontSize: this.options.tooltipFontSize,
                                caretHeight: this.options.tooltipCaretSize,
                                cornerRadius: this.options.tooltipCornerRadius,
                                text: C(this.options.tooltipTemplate, t),
                                chart: this.chart,
                                custom: this.options.customTooltips
                            }).draw()
                        }, this);
                    return this
                }
            }
        
    
        // Method to generate distributed colors for charts.
        // If chart data does not contain color or fillColor property, this method is called and try to set all colors automatically.
        getDistributedColor(input, thin){
            
            var r = Math.floor(Math.random() * 200) + Math.floor(Math.random());
            var g = 0x0;
            var b = 0x0;
            var thin_plus = ( thin )? 1:0;
            var colors_array = new Array();
            
            for( var i=0 ; ; i++ ) {
                
                if( Math.pow(i,3) >= input ) {
                    
                    var max = i - 1 + thin_plus;
                    break;
                }
            }
            
            var _plus = 0xff / max;
            for( var i=thin_plus ; i<=max ; i++ ) {
                
                r = Math.floor(Math.random() * 200) + Math.floor(Math.random());
                g = 0x0;
                b = 0x0;
                
                for( var j=thin_plus ; j<=max ; j++ ) {
                    
                    g = _plus * j;
                    b = 0x0;
                    
                    for( var k=thin_plus ; k<=max ; k++ ) {
                        
                        b = _plus * k;
                        colors_array.push( [ Math.round(r) , Math.round(g) , Math.round(b) ] );
                        if( colors_array.length >= input )return colors_array;
                    }
                    
                    if( colors_array.length >= input ) return colors_array;
                }
                
                if( colors_array.length >= input ) return colors_array;
            }
        }


        rerender(){
            this.superRerender();
            // do custom rerendering here
            this.drawChart();
        }

}