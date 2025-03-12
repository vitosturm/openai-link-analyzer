import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";

export default Component.extend({
  tagName: "",
  classNames: ["admin-openai-link-analyzer"],
  dialog: service(),
  
  apiTestResult: null,
  statistics: null,
  isLoading: false,
  
  didInsertElement() {
    this._super(...arguments);
    this.loadStatistics();
  },
  
  loadStatistics() {
    this.set("isLoading", true);
    
    ajax("/openai-link-analyzer/statistics")
      .then((result) => {
        this.set("statistics", result);
      })
      .catch(popupAjaxError)
      .finally(() => {
        this.set("isLoading", false);
      });
  },
  
  actions: {
    openSettings() {
      window.location = "/admin/site_settings/category/plugins?filter=openai_link_analyzer";
    },
    
    testApi() {
      this.set("isLoading", true);
      this.set("apiTestResult", null);
      
      ajax("/openai-link-analyzer/test_api")
        .then((result) => {
          this.set("apiTestResult", result);
        })
        .catch(popupAjaxError)
        .finally(() => {
          this.set("isLoading", false);
        });
    },
    
    clearStatistics() {
      this.dialog.confirm({
        message: I18n.t("openai_link_analyzer.admin.confirm_clear_stats"),
        didConfirm: () => {
          this.set("isLoading", true);
          
          ajax("/openai-link-analyzer/statistics/clear", {
            type: "DELETE"
          })
            .then(() => {
              this.set("statistics", {
                total_analyzed: 0,
                success_count: 0,
                failure_count: 0,
                popular_categories: {}
              });
            })
            .catch(popupAjaxError)
            .finally(() => {
              this.set("isLoading", false);
            });
        }
      });
    }
  }
}); 