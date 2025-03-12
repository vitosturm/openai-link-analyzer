import Component from "@glimmer/component";
import { inject as service } from "@ember/service";
import { action } from "@ember/object";
import I18n from "I18n";

export default class HeaderAnalyzerButton extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;

  get displayButton() {
    return (
      this.currentUser &&
      this.siteSettings.openai_link_analyzer_enabled &&
      this.router.currentRouteName !== "openaiLinkAnalyzer"
    );
  }

  get linkAnalyzerTitle() {
    return I18n.t("openai_link_analyzer.title");
  }

  @action
  navigateToAnalyzer() {
    const username = this.currentUser.username;
    this.router.transitionTo("openaiLinkAnalyzer", username);
  }
} 