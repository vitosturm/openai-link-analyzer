import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class AdminOpenaiLinkAnalyzerController extends Controller {
  @service siteSettings;
  @service dialog;
  @service messageBus;
  
  @tracked stats = {
    totalAnalyzed: 0,
    lastAnalyzed: null,
    successRate: "0%",
    popularCategories: []
  };
  @tracked isLoading = true;
  
  constructor() {
    super(...arguments);
    this.loadStats();
    
    // Subscribe to message bus for real-time updates
    this.messageBus.subscribe("/openai-link-analyzer", (data) => {
      if (data.type === "new_analysis") {
        this.loadStats();
      }
    });
  }
  
  @action
  async loadStats() {
    this.isLoading = true;
    
    try {
      // This would be a real API endpoint in a complete implementation
      // Simulating data for now
      await new Promise(resolve => setTimeout(resolve, 500));
      
      this.stats = {
        totalAnalyzed: Math.floor(Math.random() * 100),
        lastAnalyzed: new Date().toISOString(),
        successRate: `${Math.floor(85 + Math.random() * 15)}%`,
        popularCategories: [
          { name: "General", count: Math.floor(Math.random() * 50) },
          { name: "Feedback", count: Math.floor(Math.random() * 30) },
          { name: "Support", count: Math.floor(Math.random() * 20) }
        ]
      };
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.isLoading = false;
    }
  }
  
  @action
  testApiConnection() {
    this.dialog.alert({
      message: I18n.t("openai_link_analyzer.admin.api_test_result", {
        status: this.siteSettings.openai_api_key ? "success" : "failure"
      })
    });
  }
  
  @action
  clearStats() {
    this.dialog.confirm({
      message: I18n.t("openai_link_analyzer.admin.confirm_clear_stats"),
      didConfirm: () => {
        this.stats = {
          totalAnalyzed: 0,
          lastAnalyzed: null,
          successRate: "0%",
          popularCategories: []
        };
      }
    });
  }
} 