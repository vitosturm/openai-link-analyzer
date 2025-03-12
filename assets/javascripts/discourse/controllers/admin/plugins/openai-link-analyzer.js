import Controller from "@ember/controller";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { getOwner } from "@ember/owner";
import I18n from "I18n";
import bootbox from "bootbox";

export default class AdminPluginsOpenaiLinkAnalyzerController extends Controller {
  @service dialog;
  @service siteSettings;
  @service router;
  @service messageBox;
  
  @tracked loading = true;
  @tracked stats = null;
  @tracked testingAPI = false;
  @tracked apiTestResult = null;
  
  constructor() {
    super(...arguments);
    this.loadStatistics();
    
    const messageBus = getOwner(this).lookup("service:message-bus");
    
    // Subscribe to statistics updates
    messageBus.subscribe("/openai-link-analyzer/statistics", (data) => {
      if (data.updated) {
        this.loadStatistics();
      }
    });
  }
  
  @action
  async loadStatistics() {
    this.loading = true;
    
    try {
      const result = await ajax("/openai-link-analyzer/statistics");
      
      if (result.success) {
        this.stats = result.stats;
      } else {
        this.stats = null;
      }
    } catch (error) {
      this.stats = null;
      popupAjaxError(error);
    } finally {
      this.loading = false;
    }
  }
  
  @action
  async clearStatistics() {
    this.dialog.confirm({
      message: I18n.t("admin.openai_link_analyzer.confirm_clear_stats"),
      didConfirm: async () => {
        try {
          await ajax("/openai-link-analyzer/statistics/clear", {
            type: "DELETE"
          });
          
          this.stats = null;
          bootbox.alert(I18n.t("admin.openai_link_analyzer.stats_cleared"));
        } catch (error) {
          popupAjaxError(error);
        }
      }
    });
  }
  
  @action
  async testAPIConnection() {
    this.testingAPI = true;
    this.apiTestResult = null;
    
    try {
      const result = await ajax("/openai-link-analyzer/test_api");
      
      this.apiTestResult = {
        success: result.success,
        message: result.message
      };
    } catch (error) {
      this.apiTestResult = {
        success: false,
        message: error.jqXHR?.responseJSON?.message || error.message
      };
    } finally {
      this.testingAPI = false;
    }
  }
  
  @action
  openSettings() {
    this.router.transitionTo("adminSiteSettings", {
      queryParams: { filter: "openai" }
    });
  }
} 