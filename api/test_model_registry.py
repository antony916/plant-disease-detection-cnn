import unittest

from model_registry import (
    get_model_definition,
    model_summary,
    resolve_artifact_paths,
)


class ModelRegistryTest(unittest.TestCase):
    def test_disease_capability_is_available(self):
        definition = get_model_definition("disease")

        self.assertEqual(definition.status, "available")
        self.assertEqual(definition.expected_class_count, 38)
        self.assertEqual(definition.model_id, "plant-disease-mobilenetv3")

    def test_future_capabilities_are_explicitly_planned(self):
        summary = {item["capability"]: item for item in model_summary()}

        for capability in ("pest", "nutrient", "environment"):
            self.assertIn(capability, summary)
            self.assertEqual(summary[capability]["status"], "planned")

    def test_legacy_environment_alias_resolves(self):
        definition = get_model_definition("plant-stress-model")

        self.assertEqual(definition.capability, "environment")
        self.assertEqual(definition.model_id, "plant-stress-model")

    def test_unknown_capability_is_rejected(self):
        with self.assertRaises(ValueError):
            get_model_definition("unknown")

    def test_disease_artifact_paths_have_safe_defaults(self):
        definition = get_model_definition("disease")

        model_path, classes_path = resolve_artifact_paths(definition)

        self.assertEqual(
            model_path,
            "artifacts/plant_disease_mobilenetv3.pth",
        )
        self.assertEqual(classes_path, "artifacts/class_names.txt")


if __name__ == "__main__":
    unittest.main()
