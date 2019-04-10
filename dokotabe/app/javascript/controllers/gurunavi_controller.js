import { Controller } from "stimulus";
import axios from "axios";

let location = { lati: 0.0, long: 0.0 };

export default class extends Controller {
  static targets = [ "places" ]

  connect() {
    if (navigator.geolocation) {
        alert("この端末では位置情報が取得できます");
    } else {
        alert("この端末では位置情報が取得できません");
    }

    this.getLocation();
  }

  round(number, precision) {
    var shift = function (number, precision, reverseShift) {
      if (reverseShift) {
        precision = -precision;
      }  
      var numArray = ("" + number).split("e");
      return +(numArray[0] + "e" + (numArray[1] ? (+numArray[1] + precision) : precision));
    };
    return shift(Math.round(shift(number, precision, false)), precision, true);
  }

  getLocation() {
    navigator.geolocation.getCurrentPosition(
        (position) => {
            location.lati = this.round(position.coords.latitude, 8);
            location.long = this.round(position.coords.longitude, 8);
            console.log(location);
        },
        (error) => {
            switch(error.code) {
                case 1: //PERMISSION_DENIED
                    alert("位置情報の利用が許可されていません");
                    break;
                case 2: //POSITION_UNAVAILABLE
                    alert("現在位置が取得できませんでした");
                    break;
                case 3: //TIMEOUT
                    alert("タイムアウトになりました");
                    break;
                default:
                    alert("その他のエラー(エラーコード:"+error.code+")");
                break;
            }
        }
    );
  }

  getPlace() {
    const url = 'https://api.gnavi.co.jp/RestSearchAPI/v3/?keyid=' + String(gon.gurunavi_key) + '&latitude=' + String(location.lati) + '&longitude=' + String(location.long);

    axios.get(url).then((response) => {
        console.log(response);
        this.placesTarget.innerHTML = "";
        for(var i = 0; i < response.data.rest.length; i++){
            this.placesTarget.innerHTML += `
                                            <div class="card" style="width: 18rem;">
                                              <div class="card-body">
                                                <h5 class="card-title">${response.data.rest[i].name}</h5>
                                                <p class="card-text">住所：${response.data.rest[i].address}</p>
                                                <p class="card-text">TEL：${response.data.rest[i].tel}</p>
                                                <a href="${response.data.rest[i].url}" class="btn btn-primary">ボタン</a>
                                              </div>
                                            </div>
                                            `;
        }
    }, (error) => {
        console.log(error);
    })
  }
};
