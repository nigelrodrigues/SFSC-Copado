/**
 * @description array of cards to display the available topics in the community
 * @name trac_TopicNavigator
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-31
 */

import {LightningElement,api} from 'lwc';
// import Icon_Account from '@salesforce/resourceUrl/Icon_Account';
// import Icon_Gifting from '@salesforce/resourceUrl/Icon_Gifting';
// import Icon_HBCRewards from '@salesforce/resourceUrl/Icon_HBCRewards';
// import Icon_HomeFashions from '@salesforce/resourceUrl/Icon_HomeFashions';
// import Icon_OrderStatus from '@salesforce/resourceUrl/Icon_OrderStatus';
// import Icon_PaymentMethod from '@salesforce/resourceUrl/Icon_PaymentMethod';
// import Icon_Returns from '@salesforce/resourceUrl/Icon_Returns';
// import Icon_Shipping from '@salesforce/resourceUrl/Icon_Shipping';

export default class TopicNavigator extends LightningElement {

    @api panel_01;
    @api panel_02;
    @api panel_03;
    @api panel_04;
    @api panel_05;
    @api panel_06;
    @api panel_07;
    @api panel_08;

    @api panel_01_URL;
    @api panel_02_URL;
    @api panel_03_URL;
    @api panel_04_URL;
    @api panel_05_URL;
    @api panel_06_URL;
    @api panel_07_URL;
    @api panel_08_URL;

    @api panel_01_Image;
    @api panel_02_Image;
    @api panel_03_Image;
    @api panel_04_Image;
    @api panel_05_Image;
    @api panel_06_Image;
    @api panel_07_Image;
    @api panel_08_Image;

    baseUrl;

    connectedCallback() {
        let getUrl = window.location;
        this.baseUrl = getUrl.protocol + "//" + getUrl.host;

    }

    get panel_01_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_01_Image+'\') center 20px no-repeat;';
    }
    get panel_02_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_02_Image+'\') center 20px no-repeat;';
    }
    get panel_03_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_03_Image+'\') center 20px no-repeat;';
    }
    get panel_04_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_04_Image+'\') center 20px no-repeat;';
    }
    get panel_05_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_05_Image+'\') center 20px no-repeat;';
    }
    get panel_06_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_06_Image+'\') center 20px no-repeat;';
    }
    get panel_07_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_07_Image+'\') center 20px no-repeat;';
    }
    get panel_08_background_css() {
        return 'background: url(\''+this.baseUrl+this.panel_08_Image+'\') center 20px no-repeat;';
    }

}