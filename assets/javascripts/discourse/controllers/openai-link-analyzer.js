import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class OpenaiLinkAnalyzerController extends Controller {
  @service dialog;
  @service siteSettings;
  
  @tracked url = "";
  @tracked selectedCategoryId = null;
  @tracked categories = [];
  @tracked isProcessing = false;
  @tracked lastResult = null;
  @tracked lastError = null;
  
  constructor() {
    super(...arguments);
    this.fetchCategories();
  }
  
  @action
  async fetchCategories() {
    try {
      const response = await ajax("/openai-link-analyzer/categories");
      this.categories = response.categories;
    } catch (error) {
      popupAjaxError(error);
    }
  }
  
  @action
  updateUrl(event) {
    this.url = event.target.value;
  }
  
  @action
  updateCategory(categoryId) {
    this.selectedCategoryId = categoryId;
  }
  
  @action
  async analyzeUrl() {
    if (!this.url) {
      this.lastError = "Please enter a URL";
      return;
    }
    
    if (!this.selectedCategoryId) {
      this.lastError = "Please select a category";
      return;
    }
    
    this.lastError = null;
    this.lastResult = null;
    this.isProcessing = true;
    
    try {
      const result = await ajax("/openai-link-analyzer/analyze", {
        type: "POST",
        data: {
          url: this.url,
          category_id: this.selectedCategoryId
        }
      });
      
      this.lastResult = result;
      this.url = "";
      this.selectedCategoryId = null;
    } catch (error) {
      this.lastError = error.jqXHR?.responseJSON?.error || "An error occurred while processing your request";
      popupAjaxError(error);
    } finally {
      this.isProcessing = false;
    }
  }
} 