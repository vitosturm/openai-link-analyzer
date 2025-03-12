import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

acceptance("OpenAI Link Analyzer - User Interface", function (needs) {
  needs.user();
  needs.settings({
    openai_link_analyzer_enabled: true,
  });
  
  test("Plugin UI is visible for logged in users", async function (assert) {
    await visit("/u/eviltrout/openai-link-analyzer");
    
    assert.ok(exists(".openai-link-analyzer-container"), "Plugin container is visible");
    assert.ok(exists(".analyzer-form"), "Analyzer form is visible");
    assert.ok(exists("#url-input"), "URL input field is visible");
    assert.ok(exists(".analyze-button"), "Analyze button is visible");
  });
});

acceptance("OpenAI Link Analyzer - Admin Interface", function (needs) {
  needs.user({ admin: true });
  
  test("Admin panel is accessible for admins", async function (assert) {
    await visit("/admin/plugins/openai-link-analyzer");
    
    assert.ok(exists(".admin-openai-link-analyzer"), "Admin panel is visible");
    assert.ok(exists(".admin-controls"), "Admin controls are visible");
    assert.ok(exists(".statistics-cards"), "Statistics cards are visible");
  });
}); 