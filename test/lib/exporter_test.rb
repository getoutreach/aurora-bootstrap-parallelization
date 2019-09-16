require 'test_helper'

class ExporterTest < Minitest::Test
  def setup
    @config =   { "env" => { "DB_HOST" => "localhost",
                             "RB_USER" => "root",
                             "DB_PASS" => "root",
                              "PREFIX" => "",
                       "EXPORT_BUCKET" => "",
                  "BLACKLISTED_TABLES" => "",
                  "BLACKLISTED_FIELDS" => "" },
              "version" => "0.1.0.9",
                 "name" => "test-exporter" }
    @exporter = AuroraBootstrapParallelization::Exporter.new @config
  end

  def test_manifest
    assert_equal( {"apiVersion"=>"batch/v1", "kind"=>"Job", "metadata"=>{"labels"=>{"app"=>"test-exporter", "name"=>"test-exporter"}, "name"=>"test-exporter", "namespace"=>"aurora-bootstrap"}, "spec"=>{"backoffLimit"=>10, "completions"=>1, "parallelism"=>1, "template"=>{"metadata"=>{"annotations"=>{"cluster-autoscaler.kubernetes.io/safe-to-evict"=>"true", "iam.amazonaws.role"=>""}, "creationTimestamp"=>nil, "labels"=>{"app"=>"test-exporter", "job-name"=>"test-exporter", "name"=>"test-exporter"}}, "spec"=>{"containers"=>[{"env"=>{"DB_HOST"=>"localhost", "RB_USER"=>"root", "DB_PASS"=>"root", "PREFIX"=>"", "EXPORT_BUCKET"=>"", "BLACKLISTED_TABLES"=>"", "BLACKLISTED_FIELDS"=>""}, "image"=>"gaorlov/aurora-bootstrap:0.1.0.9", "imagePullPolicy"=>"Always", "name"=>"test-exporter", "resources"=>{"limits"=>{"cpu"=>"100m", "memory"=>"300Mi"}, "requests"=>{"cpu"=>"100m"}}, "terminationMessagePath"=>"/dev/termination-log", "terminationMessagePolicy"=>"File"}], "dnsConfig"=>{"options"=>[{"name"=>"ndots", "value"=>"1"}]}, "dnsPolicy"=>"ClusterFirst", "restartPolicy"=>"OnFailure", "schedulerName"=>"default-scheduler", "securityContext"=>{}, "terminationGracePeriodSeconds"=>30}}}},
                  @exporter.manifest )
  end

  def test_file_name
    assert_equal "test-exporter-job.yml", @exporter.file_name
  end

  def test_write_manifest
    manifest = <<~YAML
      ---
      apiVersion: batch/v1
      kind: Job
      metadata:
        labels:
          app: test-exporter
          name: test-exporter
        name: test-exporter
        namespace: aurora-bootstrap
      spec:
        backoffLimit: 10
        completions: 1
        parallelism: 1
        template:
          metadata:
            annotations:
              cluster-autoscaler.kubernetes.io/safe-to-evict: 'true'
              iam.amazonaws.role: ''
            creationTimestamp: 
            labels:
              app: test-exporter
              job-name: test-exporter
              name: test-exporter
          spec:
            containers:
            - env:
                DB_HOST: localhost
                RB_USER: root
                DB_PASS: root
                PREFIX: ''
                EXPORT_BUCKET: ''
                BLACKLISTED_TABLES: ''
                BLACKLISTED_FIELDS: ''
              image: gaorlov/aurora-bootstrap:0.1.0.9
              imagePullPolicy: Always
              name: test-exporter
              resources:
                limits:
                  cpu: 100m
                  memory: 300Mi
                requests:
                  cpu: 100m
              terminationMessagePath: "/dev/termination-log"
              terminationMessagePolicy: File
            dnsConfig:
              options:
              - name: ndots
                value: '1'
            dnsPolicy: ClusterFirst
            restartPolicy: OnFailure
            schedulerName: default-scheduler
            securityContext: {}
            terminationGracePeriodSeconds: 30
    YAML
    File.stub( :open, DummyFile.new ) do
      assert_output manifest do
        @exporter.write_manifest
      end
    end
  end
end