import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

const generateRandomNumber = () => {
    return Math.round(Math.random() * 100);
};
import ChartJS from '@salesforce/resourceUrl/ChartJSNew';

export default class ChartTest extends LightningElement {

    @api charttitle = "Accounts Without Activity";
    @api chartLegend;
    @api chartdata
    @api chartList = [];
    error;
    chart;
    chartjsInitialized = false;

    testconfig = {
        type: 'pie',
        data: {
            datasets: [
                {
                    data: [
                        generateRandomNumber(),
                        generateRandomNumber(),
                        generateRandomNumber(),
                        generateRandomNumber(),
                        generateRandomNumber()
                    ],
                    backgroundColor: [
                        'rgb(255, 99, 132)',
                        'rgb(255, 159, 64)',
                        'rgb(255, 205, 86)',
                        'rgb(75, 192, 192)',
                        'rgb(54, 162, 235)'
                    ],
                    label: 'Dataset 1'
                }
            ],
            labels: ['Red', 'Orange', 'Yellow', 'Green', 'Blue']
        },
        options: {
            responsive: true,
            legend: {
                position: 'right'
            },
            animation: {
                animateScale: true,
                animateRotate: true
            }
        }
    };

    renderedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;

        Promise.all([
            loadScript(this, ChartJS + '/package/dist/Chart.min.js'),
            loadStyle(this, ChartJS + '/package/dist/Chart.min.css')
            ])
            .then(() => {
                        let chartdata = {...this.chartdata};
                        console.log('Chart Data rhcChart: ' + chartdata);
                        var haschartdata = false;
                        var arr = new Array();
                        if(Object.keys(chartdata).length > 0){
                            haschartdata = true;
                            }
                        console.log('chartData[0].value: ' + chartdata[0].value);
                        console.log('chartData[0].label: ' + chartdata[0].label);
                        console.log('chartData[0].legendLabel: ' + chartdata[0].legendLabel);
                        console.log('chartData[0].colorVal: ' + chartdata[0].colorVal);
                        console.log('Keys: ' + Object.keys(chartdata).length);
                        if(chartdata[0].value != null && Object.keys(chartdata).length > 0){
                            var dataList = [];
                            var colorList = [];
                            var labelList = [];
                            for(var i = 0; i < Object.keys(chartdata).length; i++){
                                dataList.push(chartdata[i].value);
                                colorList.push(chartdata[i].colorVal);
                                labelList.push(chartdata[i].label);
                                }

                            var chartconfig = {
                                type: 'pie',
                                data: {
                                    datasets: [
                                                {
                                                data: dataList,
                                                backgroundColor: colorList,
                                                label: labelList
                                                }
                                                ],
                                    labels: labelList
                                    },
                                options: {
                                    maintainAspectRatio: false,
                                        responsive: true,
                                        legend: {
                                        position: 'right'
                                        },
                                animation: {
                                            animateScale: true,
                                            animateRotate: true
                                            }
                                        }
                                }
                            }
                        if(haschartdata){
                            const canvas = document.createElement('canvas');
                            const ctx = canvas.getContext('2d');
                            // disable Chart.js CSS injection
                            window.Chart.platform.disableCSSInjection = true;
                            this.template.querySelector('div.chart').appendChild(canvas);
                            this.chart = new window.Chart(ctx, chartconfig);
                            console.log('Loaded Chart With Data');
                            }
                        else{
                            const canvas = document.createElement('canvas');
                            const ctx = canvas.getContext('2d');
                            ctx.font = "20px Verdana";
                            ctx.textAlign = "left";
                            ctx.textBaseline = "middle";
                            ctx.fillStyle = "grey";
                            ctx.fillText("No data in chart.", 100, 100);
                            this.template.querySelector('div.chart').appendChild(canvas);
                            }
                        })
                    .catch((error) => {
                        this.error = error;
                        console.log('Error: '+ this.error);
                        });
        }

}