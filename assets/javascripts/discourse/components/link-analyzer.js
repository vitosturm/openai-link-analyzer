import Component from "@ember/component";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { inject as service } from "@ember/service";

export default Component.extend({
  tagName: "",
  classNames: ["openai-link-analyzer"],
  router: service(),
  dialog: service(),
  
  url: "",
  categoryId: null,
  isAnalyzing: false,
  lastError: null,
  lastResult: null,
  categories: null,
  
  didInsertElement() {
    this._super(...arguments);
    this.loadCategories();
  },
  
  loadCategories() {
    ajax("/openai-link-analyzer/categories").then((result) => {
      this.set("categories", result.categories);
    }).catch(popupAjaxError);
  },
  
  actions: {
    updateUrl(event) {
      this.set("url", event.target.value);
    },

    updateCategory(categoryId) {
      this.set("categoryId", categoryId);
    },
    
    analyzeUrl() {
      this.set("isAnalyzing", true);
      this.set("lastError", null);
      
      if (!this.url) {
        this.set("lastError", I18n.t("openai_link_analyzer.errors.url_required"));
        this.set("isAnalyzing", false);
        return;
      }
      
      if (!this.categoryId) {
        this.set("lastError", I18n.t("openai_link_analyzer.errors.category_required"));
        this.set("isAnalyzing", false);
        return;
      }
      
      ajax("/openai-link-analyzer/analyze", {
        type: "POST",
        data: {
          url: this.url,
          category_id: this.categoryId
        }
      }).then((result) => {
        this.set("lastResult", result);
        this.set("url", "");  // Clear the form after successful analysis
        this.set("isAnalyzing", false);
      }).catch((error) => {
        this.set("lastError", error.jqXHR?.responseJSON?.error || I18n.t("openai_link_analyzer.errors.unknown_error"));
        this.set("isAnalyzing", false);
      });
    },
    
    viewTopic() {
      if (this.lastResult && this.lastResult.topic_url) {
        window.location = this.lastResult.topic_url;
      }
    }
  }
}); 